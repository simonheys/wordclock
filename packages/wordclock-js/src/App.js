import WordClock from "./components/WordClock";

import styles from "./App.module.scss";
import React from "react";

const App = () => {
  const [words, setWords] = React.useState();
  const loadJson = async (url) => {
    const response = await fetch("/English_simple_fragmented.json");
    const json = await response.json();
    setWords(json);
  };

  React.useEffect(() => {
    loadJson();
  }, []);

  return (
    <div className={styles.container}>
      <WordClock words={words} />
    </div>
  );
};

export default App;
