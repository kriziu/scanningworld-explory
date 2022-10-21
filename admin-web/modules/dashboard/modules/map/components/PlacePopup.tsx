import { AiOutlineClose } from 'react-icons/ai';
import { Popup } from 'react-leaflet';

import PlaceModal from '@/modules/dashboard/modals/PlaceModal';
import { useActivePlace } from '@/modules/dashboard/recoil/activePlace';
import { useChangePlaceLocation } from '@/modules/dashboard/recoil/placeLocation';
import { useModal } from '@/modules/modal';

const PlacePopup = () => {
  const { openModal } = useModal();
  const { placeLocation, setPlaceToActiveLocation } = useChangePlaceLocation();
  const { activePlace, setActivePlace } = useActivePlace();

  if (!activePlace || placeLocation.active) return null;

  const { location, name, description, points, imageUri } = activePlace;

  const handleChangeLocation = () => {
    setPlaceToActiveLocation(
      (newLocation) => console.log(newLocation),
      activePlace._id
    );
  };

  return (
    <Popup
      position={location}
      offset={[0, -25]}
      closeButton={false}
      closeOnClick={false}
    >
      <div className="relative h-full">
        <div className="mb-5 flex items-center justify-between">
          <h1 className="pr-10 text-xl font-bold">{name}</h1>
          <button
            className="btn absolute -right-4 text-xl hover:bg-zinc-200"
            onClick={() => setActivePlace(null)}
          >
            <AiOutlineClose />
          </button>
        </div>

        <div className="flex gap-5">
          <div>
            <img
              src={imageUri || 'images/placeholder.jpg'}
              alt="olza"
              className="h-48 w-48 rounded-2xl object-cover"
            />

            <button className="btn mt-3 w-full bg-black text-white hover:bg-black/80 active:bg-black">
              Pokaż kod QR
            </button>
          </div>

          <div className="flex h-48 flex-1 flex-col justify-between">
            <p className="flex-1 text-justify text-[.9rem] leading-6">
              {description}
            </p>

            <div className="mt-4 flex items-center justify-between">
              <p className="text-lg font-bold text-primary">
                {location.lat} / {location.lng}
              </p>
              <p className="text-center text-lg font-bold">{points} punktów</p>
            </div>
          </div>
        </div>

        <div className="mt-3 flex w-full justify-end gap-5">
          <button
            className="btn btn-secondary"
            onClick={() => openModal(<PlaceModal />)}
          >
            Edytuj informacje
          </button>
          <button className="btn btn-primary" onClick={handleChangeLocation}>
            Zmień położenie
          </button>
        </div>
      </div>
    </Popup>
  );
};

export default PlacePopup;
