import { JSX as JSX_2 } from 'react/jsx-runtime';

declare type Group = {
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

export declare const WordClock: ({ words }: {
    words: WordsJson;
}) => JSX_2.Element;

declare interface WordsJson {
    meta: {
        language: string;
        title: string;
    };
    groups: Group[][];
}

export { }
