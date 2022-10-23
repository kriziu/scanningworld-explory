import { QueryClient, QueryClientProvider } from '@tanstack/react-query';
import { MotionConfig } from 'framer-motion';
import type { AppProps } from 'next/app';
import Head from 'next/head';
import { RecoilRoot } from 'recoil';

import { setupAxios } from '@/common/lib/setupAxios';
import { ModalManager } from '@/modules/modal';

import '../common/styles/global.css';

const queryClient = new QueryClient();

setupAxios();

const App = ({ Component, pageProps }: AppProps) => {
  return (
    <>
      <Head>
        <title>Zarządaj rejonem | scanningworld</title>
        <link rel="icon" href="/logo.ico" />
      </Head>
      <RecoilRoot>
        <QueryClientProvider client={queryClient}>
          <MotionConfig transition={{ ease: [0.6, 0.01, -0.05, 0.9] }}>
            <ModalManager />
            <div
              className="absolute top-0 left-0 flex h-full w-full items-center justify-center rounded-none bg-black lg:hidden"
              style={{ zIndex: 9999 }}
            >
              <h1 className="p-5 text-center text-white">
                Zaloguj się na komputerze, aby móc zarządzać rejonem
                {/* TODO: dodac modul kuponow, naprawic bug ze sie nie aktualizuje */}
              </h1>
            </div>
            <Component {...pageProps} />
          </MotionConfig>
        </QueryClientProvider>
      </RecoilRoot>
    </>
  );
};

export default App;
