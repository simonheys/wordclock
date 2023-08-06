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
}) => JSX.Element;

declare interface WordsJson {
    meta: {
        language: string;
        title: string;
    };
    groups: Group[][];
}

export { }
