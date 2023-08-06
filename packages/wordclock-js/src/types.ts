export interface Manifest {
  files: string[];
  languages: Record<string, string>;
}

export interface WordsEntry {
  file: string;
  title: string;
}

export type Group =
  | {
      type: "sequence";
      bind: "hour" | "minute" | "second";
      first: number;
      text: string[];
    }
  | {
      type: "item";
      items: {
        highlight: string;
        text?: string;
      }[];
    }
  | {
      type: "space";
      count: number;
    };

export interface WordsJson {
  meta: {
    language: string;
    title: string;
  };
  groups: Group[][];
}

export type Words = Record<string, WordsEntry[]>;

export type WordsLabel = string[][];
export type WordsLogic = string[][];
