import * as React from "react";
import { useTimeProps } from "../hooks/useTimeProps";

const WordClock = () => {
  const timeProps = useTimeProps();
  return <pre>{JSON.stringify(timeProps, null, 2)}</pre>;
};

export default WordClock;
