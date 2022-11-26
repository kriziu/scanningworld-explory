import { AiFillPieChart } from 'react-icons/ai';

import StatisticsModal from '@/modules/dashboard/modals/StatisticsModal';
import { useModal } from '@/modules/modal';

const StatisticsButton = () => {
  const { openModal } = useModal();

  return (
    <button
      className="btn btn-primary flex items-center gap-2 bg-black hover:bg-black/70 active:bg-black"
      onClick={() => {
        openModal(<StatisticsModal />);
      }}
    >
      <AiFillPieChart />
      Statystyki rejonu
    </button>
  );
};

export default StatisticsButton;
