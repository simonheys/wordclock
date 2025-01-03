import { render, screen } from "@testing-library/react";
import { expect, test } from "vitest";

const json: WordsJson = require(`@simonheys/wordclock-words/json/English.json`);

import { WordsJson } from "./types";
import { WordClock } from "./WordClock";
import { WordClockContent } from "./WordClockContent";

test("renders English.json text", async () => {
  render(
    <WordClock words={json}>
      <WordClockContent />
    </WordClock>,
  );
  const fivePastText = await screen.findByText("Five past");
  expect(fivePastText).toBeInTheDocument();
});
