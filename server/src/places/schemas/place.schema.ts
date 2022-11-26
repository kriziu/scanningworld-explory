import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';

import mongoose, { Document } from 'mongoose';

import { RegionDocument } from 'src/regions/schemas/region.schema';
import { UserDocument } from 'src/users/schemas/user.schema';

export type PlaceDocument = Place & Document;

@Schema()
export class Place {
  @Prop()
  name: string;

  @Prop()
  description: string;

  @Prop()
  imageUri: string;

  @Prop({
    type: mongoose.Schema.Types.ObjectId,
    ref: 'Region',
    autopopulate: true,
  })
  region: RegionDocument;

  @Prop()
  points: number;

  @Prop({ type: { lat: Number, lng: Number } })
  location: {
    lat: number;
    lng: number;
  };

  @Prop({
    type: [
      {
        user: {
          type: mongoose.Schema.Types.ObjectId,
          ref: 'User',
          autopopulate: true,
        },
        rating: Number,
        comment: String,
      },
    ],
    default: [],
  })
  reviews: {
    user: UserDocument;
    rating: number;
    comment: string;
  }[];

  @Prop({ default: 0 })
  averageRating: number;

  @Prop({ select: false })
  code: string;

  @Prop({ default: 0 })
  scanCount: number;
}

export const PlaceSchema = SchemaFactory.createForClass(Place);
