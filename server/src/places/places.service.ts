import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';

import { v2 } from 'cloudinary';
import { isValidObjectId, Model } from 'mongoose';

import { RegionsService } from 'src/regions/regions.service';
import { UsersService } from 'src/users/users.service';
import { UserDocument } from 'src/users/schemas/user.schema';

import { Place, PlaceDocument } from './schemas/place.schema';
import { CreatePlaceDto } from './dto/createPlace.dto';
import { calcDistance } from './lib/distance';
import { UpdatePlaceDto } from './dto/updatePlace.dto';
import { ReviewPlaceDto } from './dto/reviewPlace.dto';

@Injectable()
export class PlacesService {
  constructor(
    @InjectModel(Place.name) private placeModel: Model<PlaceDocument>,
    private regionsService: RegionsService,
    private usersService: UsersService,
  ) {}

  async create(
    regionId: string,
    createPlaceDto: CreatePlaceDto,
  ): Promise<PlaceDocument> {
    const { lng, lat, ...place } = createPlaceDto;

    if (!isValidObjectId(regionId)) {
      throw new BadRequestException('Invalid region id');
    }

    const region = await this.regionsService.findById(regionId);

    if (!region) {
      throw new NotFoundException('Region not found');
    }

    const code =
      Math.random().toString(36).substring(2, 15) +
      Math.random().toString(36).substring(2, 15);

    const imageUri = !place.imageBase64
      ? ''
      : await v2.uploader
          .upload(place.imageBase64, {
            folder: 'scanningworld',
          })
          .then((result) => {
            return result.url;
          });

    this.regionsService.updateRegionPlacesCount(regionId, 1);

    return this.placeModel.create({
      ...place,
      region: regionId,
      location: { lat, lng },
      code,
      imageUri,
    });
  }

  async update(
    regionId: string,
    id: string,
    updatePlaceDto: UpdatePlaceDto,
  ): Promise<PlaceDocument> {
    if (!isValidObjectId(regionId)) {
      throw new BadRequestException('Invalid region id');
    }

    const { lng, lat } = updatePlaceDto;
    const place = await this.placeModel.findById(id).exec();

    if (!place) {
      throw new NotFoundException('Place not found');
    }

    if (place.region._id.toString() !== regionId) {
      throw new BadRequestException('You cannot update this place');
    }

    const imageUri = !updatePlaceDto.imageBase64
      ? place.imageUri
      : await v2.uploader
          .upload(updatePlaceDto.imageBase64, {
            folder: 'scanningworld',
          })
          .then((result) => {
            return result.url;
          });

    return this.placeModel
      .findByIdAndUpdate(
        id,
        {
          ...updatePlaceDto,
          imageUri,
          location: {
            lng: lng || place.location.lng,
            lat: lat || place.location.lat,
          },
        },
        { new: true },
      )
      .exec();
  }

  async delete(regionId: string, id: string): Promise<PlaceDocument> {
    if (!isValidObjectId(id)) {
      throw new BadRequestException('Invalid place id');
    }

    const place = await this.placeModel.findById(id).exec();

    if (!place) {
      throw new NotFoundException('Place not found');
    }

    if (place.region._id.toString() !== regionId) {
      throw new BadRequestException('You cannot delete this place');
    }

    this.regionsService.updateRegionPlacesCount(
      place.region._id.toString(),
      -1,
    );

    const userModel = this.usersService.getUserModel();

    await userModel
      .updateMany({ scannedPlaces: id }, { $pull: { scannedPlaces: id } })
      .exec();

    return this.placeModel.findByIdAndDelete(id).exec();
  }

  async findAll(): Promise<PlaceDocument[]> {
    return this.placeModel.find().exec();
  }

  async findByRegionId(
    regionId: string,
    { code }: { code?: boolean } = {},
  ): Promise<PlaceDocument[]> {
    if (!isValidObjectId(regionId)) {
      throw new BadRequestException('Invalid region id');
    }

    const region = await this.regionsService.findById(regionId);

    if (!region) {
      throw new NotFoundException('Region not found');
    }

    return this.placeModel
      .find({ region: regionId })
      .select(code && '+code')
      .exec();
  }

  async reviewPlace(
    placeId: string,
    userId: string,
    reviewPlaceDto: ReviewPlaceDto,
  ): Promise<PlaceDocument> {
    if (!isValidObjectId(placeId)) {
      throw new BadRequestException('Invalid place id');
    }

    const place = await this.placeModel.findById(placeId).exec();

    if (!place) {
      throw new NotFoundException('Place not found');
    }

    const user = await this.usersService.findById(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    const reviewByUser = place.reviews.find(
      (review) => review.user._id.toString() === userId,
    );

    if (reviewByUser) {
      throw new BadRequestException('You already reviewed this place');
    }

    return await this.placeModel
      .findByIdAndUpdate(
        placeId,
        {
          $push: {
            reviews: {
              user: userId,
              reviewDate: new Date(),
              ...reviewPlaceDto,
            },
          },
          averageRating:
            ((place.averageRating || 0) * place.reviews.length +
              reviewPlaceDto.rating) /
            (place.reviews.length + 1),
        },
        { new: true },
      )
      .exec();
  }

  async scanCode(
    code: string,
    userId: string,
    location: { lat: number; lng: number },
  ): Promise<UserDocument> {
    const place = await this.placeModel.findOne({ code }).exec();

    if (!place) {
      throw new NotFoundException('Place not found');
    }

    const user = await this.usersService.findById(userId);

    if (!user) {
      throw new NotFoundException('User not found');
    }

    if (user.region._id.toString() !== place.region._id.toString()) {
      throw new BadRequestException(
        'User is not in the same region as the place',
      );
    }

    if (
      user.scannedPlaces.find(
        (userPlace) => userPlace._id.toString() === place._id.toString(),
      )
    ) {
      throw new BadRequestException('User has already visited this place');
    }

    const distance = calcDistance(
      place.location.lat,
      place.location.lng,
      location.lat,
      location.lng,
    );

    if (distance > 1000) {
      throw new BadRequestException('User is not close enough to the place');
    }

    const regionId = user.region._id.toString();

    await place.updateOne({ $inc: { scanCount: 1 } }).exec();

    return await this.usersService.update(userId, {
      scannedPlaces: [...user.scannedPlaces, place._id],
      points: {
        ...user.points,
        [regionId]: (user.points[regionId] || 0) + place.points,
      },
    });
  }
}
