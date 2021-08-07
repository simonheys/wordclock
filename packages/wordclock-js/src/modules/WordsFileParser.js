export const parseJson = ({ groups }) => {
  const label = [];
  const logic = [];
  groups.forEach((group) => {
    const groupLabel = [];
    const groupLogic = [];
    group.forEach((entry) => {
      const type = entry.type;
      if (type === "item") {
        const items = entry.items;
        items.forEach((item) => {
          const highlight = item.highlight;
          const text = item.text || "";
          groupLabel.push(text);
          groupLogic.push(highlight);
        });
      } else if (type === "sequence") {
        const bind = entry.bind;
        const first = entry.first;
        const textArray = entry.text;
        textArray.forEach((text, index) => {
          const highlight = `${bind}==${first + index}`;
          groupLabel.push(text);
          groupLogic.push(highlight);
        });
      } else if (type === "space") {
        const count = entry.count;
        for (let i = 0; i < count; i++) {
          groupLabel.push("");
          groupLogic.push("");
        }
      }
    });
    logic.push(groupLogic);
    label.push(groupLabel);
  });

  return { logic, label };
};
