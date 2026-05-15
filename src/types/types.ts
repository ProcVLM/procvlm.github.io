export type Author = {
  name: string;
  url?: string;
  institution?: string;
  notes?: string[];
};

export type Link = {
  url?: string;
  name: string;
  icon?: string;
  items?: {
    url: string;
    name: string;
  }[];
};

export type Note = {
  symbol: string;
  text: string;
};
