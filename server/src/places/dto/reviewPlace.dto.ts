import { IsInt, Max, Min } from 'class-validator';

export class ReviewPlaceDto {
  @IsInt()
  @Min(1)
  @Max(5)
  readonly rating: number;

  readonly comment: string;
}
