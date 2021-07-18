import WordClock from "./components/WordClock";

import styles from "./App.module.scss";

const App = () => {
  return (
    <div className={styles.container}>
      <WordClock />
    </div>
  );
};

export default App;
