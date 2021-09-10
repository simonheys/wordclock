import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders learn react link", async () => {
  render(<App />);
  await screen.findByText(/one/i);
  const linkElement = screen.getByText(/one/i);
  expect(linkElement).toBeInTheDocument();
});
