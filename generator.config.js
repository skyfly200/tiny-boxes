module.exports = {
  templates: [
    {
      name: "component",
      label: "Component",
      template: {
        ["./src/components/${name.pascalCase}.vue"]: "component.vue"
      },
      renameFile: true, // Rename file question
      prompts: [
        // Custom Questions
        {
          type: "confirm",
          name: "scoped",
          message: "This component with scoped styling?",
          default: true,
          group: "component",
          when: answers => answers.type === "component"
        }
      ]
    }
  ]
};
