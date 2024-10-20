import { FC } from 'react';
import { HTMLAttributes } from 'react';
import { PropsWithChildren } from 'react';
import { Provider } from 'react';

declare const getTimeProps: (dateInstance?: Date) => {
    day: number;
    daystartingmonday: number;
    date: number;
    month: number;
    hour: number;
    twentyfourhour: number;
    minute: number;
    second: number;
};

export declare type Group = {
    type: "sequence";
    bind: "hour" | "minute" | "second";
    first: number;
    text: string[];
} | {
    type: "item";
    items: {
        highlight: string;
        text?: string;
    }[];
} | {
    type: "space";
    count: number;
};

export declare interface Manifest {
    files: string[];
    languages: Record<string, string>;
}

declare type TimeProps = ReturnType<typeof getTimeProps>;

export declare const useWordClock: () => WordClockContentProps;

export declare const WordClock: FC<WordClockProps>;

export declare const WordClockContent: FC<WordClockContentProps_2>;

declare interface WordClockContentProps {
    logic: WordsLogic;
    label: WordsLabel;
    timeProps: TimeProps;
}

declare interface WordClockContentProps_2 {
    wordComponent?: FC<WordClockWordProps>;
}

declare interface WordClockProps extends HTMLAttributes<HTMLDivElement> {
    words: WordsJson;
}

export declare const WordClockProvider: Provider<WordClockContentProps | null>;

export declare const WordClockWord: FC<WordClockWordProps>;

export declare interface WordClockWordProps extends PropsWithChildren {
    highlighted: boolean;
}

export declare type Words = Record<string, WordsEntry[]>;

export declare interface WordsEntry {
    file: string;
    title: string;
}

export declare interface WordsJson {
    meta: {
        language: string;
        title: string;
    };
    groups: Group[][];
}

export declare type WordsLabel = string[][];

export declare type WordsLogic = string[][];

export { }
