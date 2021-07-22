import WordClock from "./components/WordClock";

import styles from "./App.module.scss";
import React from "react";

const wordsCollection = {
  A: require("wordclock-words/json/Albanian.json"),
  B: require("wordclock-words/json/Chinese.json"),
};

const App = () => {
  const [words, setWords] = React.useState(wordsCollection["A"]);

  return (
    <div className={styles.container}>
      <WordClock words={words} />
      <div onClick={() => setWords(wordsCollection["A"])}>Words A</div>
      <div onClick={() => setWords(wordsCollection["B"])}>Words B</div>
    </div>
  );
};

export default App;
