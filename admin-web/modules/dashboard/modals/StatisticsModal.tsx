import { useQuery } from '@tanstack/react-query';
import axios from 'axios';
import { Chart as ChartJS, ArcElement, Tooltip, Legend } from 'chart.js';
import { Pie } from 'react-chartjs-2';

import Spinner from '@/common/components/Spinner';
import { useRegion } from '@/common/recoil/region';

import type { PlaceType } from '../types/place.type';

ChartJS.register(ArcElement, Tooltip, Legend);

const StatisticsModal = () => {
  const {
    region: { _id },
  } = useRegion();

  const { data, error, isLoading } = useQuery(
    ['places'],
    () => axios.get<PlaceType[]>(`places/as-region`).then((res) => res.data),
    { enabled: !!_id }
  );

  if (error) {
    return <div>Wystąpił błąd</div>;
  }

  if (isLoading || !data) {
    return <Spinner />;
  }

  const chartData = {
    labels: data.map((place) => place.name),
    datasets: [
      {
        label: 'Liczba zeskanowań kodu QR',
        data: data.map((place) => place.scanCount),
        backgroundColor: [
          'rgba(255, 99, 132, 0.2)',
          'rgba(54, 162, 235, 0.2)',
          'rgba(255, 206, 86, 0.2)',
          'rgba(75, 192, 192, 0.2)',
          'rgba(153, 102, 255, 0.2)',
          'rgba(255, 159, 64, 0.2)',
        ],
        borderColor: [
          'rgba(255, 99, 132, 1)',
          'rgba(54, 162, 235, 1)',
          'rgba(255, 206, 86, 1)',
          'rgba(75, 192, 192, 1)',
          'rgba(153, 102, 255, 1)',
          'rgba(255, 159, 64, 1)',
        ],
        borderWidth: 1,
      },
    ],
  };

  return (
    <div className="flex h-[34rem] w-[40rem] flex-col items-center gap-3 pb-10">
      <h1 className="text-center text-lg font-semibold">Statystyki</h1>

      <Pie data={chartData} />
    </div>
  );
};

export default StatisticsModal;
