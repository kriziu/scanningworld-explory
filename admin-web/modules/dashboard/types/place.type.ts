import { RegionType } from '@/common/types/region.type';

export type PlaceType = {
  _id: string;
  name: string;
  location: {
    lat: number;
    lng: number;
  };
  description: string;
  imageUri: string;
  points: number;
  code: string;
  region: RegionType;
  scanCount: number;
  // reviews: any[];
  // averageRating: number; // TODO: Add reviews to see for admin side, activateCount for coupons
};

export type PlaceValues = {
  name: string;
  description: string;
  points: number;
  location: { lat: number; lng: number };
  imageUri: string;
};

export interface PostPlace extends Omit<PlaceValues, 'imageUri' | 'location'> {
  imageBase64: string;
  lat: number;
  lng: number;
}
