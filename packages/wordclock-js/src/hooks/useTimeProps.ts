import { useEffect, useState } from "react";

export type TimeProps = ReturnType<typeof getTimeProps>;

export const getTimeProps = (dateInstance = new Date()) => {
  const day = dateInstance.getDay();
  let daystartingmonday = day - 1;
  while (daystartingmonday < 0) {
    daystartingmonday += 7;
  }

  const date = dateInstance.getDate();
  const month = dateInstance.getMonth();
  const hour = dateInstance.getHours() % 12;
  const twentyfourhour = dateInstance.getHours();
  const minute = dateInstance.getMinutes();
  const second = dateInstance.getSeconds();

  return {
    day,
    daystartingmonday,
    date,
    month,
    hour,
    twentyfourhour,
    minute,
    second,
  };
};

const useTimeProps = () => {
  const [timeProps, setTimeProps] = useState(getTimeProps());
  useEffect(() => {
    const interval = setInterval(() => {
      setTimeProps(getTimeProps());
    }, 1000);
    return () => clearInterval(interval);
  }, []);
  return timeProps;
};

export default useTimeProps;
