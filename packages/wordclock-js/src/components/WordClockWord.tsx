import { CSSProperties, FC, PropsWithChildren } from "react";

export interface WordClockWordProps extends PropsWithChildren {
  highlighted: boolean;
}

const wordStyle: CSSProperties = {
  marginRight: "0.2em",
  transition: "color 0.15s",
};

export const WordClockWord: FC<WordClockWordProps> = ({
  highlighted,
  ...rest
}) => {
  return (
    <div
      style={{
        ...wordStyle,
        color: highlighted ? "#ff0000" : "inherit",
      }}
      {...rest}
    />
  );
};
