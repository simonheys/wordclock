import WordClock from "./components/WordClock";

import styles from "./App.module.scss";
import React from "react";

const App = () => {
  const [words, setWords] = React.useState();
  const [large, setLarge] = React.useState(false);

  const toggleLarge = React.useCallback(
    (e) => {
      e.preventDefault();
      setLarge(!large);
    },
    [large]
  );

  const loadJson = async (url) => {
    const response = await fetch("/English_simple_fragmented.json");
    const json = await response.json();
    setWords(json);
  };

  React.useEffect(() => {
    loadJson();
  }, []);

  return (
    <div className={large ? styles.containerLarge : styles.container}>
      <WordClock words={words} />
      <div onClick={toggleLarge}>Toggle large</div>
    </div>
  );
};

export default App;
