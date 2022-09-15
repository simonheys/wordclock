import { render, screen } from "@testing-library/react";
import App from "./App";

test("renders Mounted text", async () => {
  render(<App />);
  await screen.findByText(/Mounted/i);
  const element = screen.getByText(/Mounted/i);
  expect(element).toBeInTheDocument();
});
