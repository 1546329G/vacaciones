module.exports = {
  root: true,
  env: {
    es6: true,
    node: true,
  },
  parserOptions: {
    ecmaVersion: 2020,
  },
  extends: [
    "eslint:recommended",
    "google",
  ],
  rules: {
    "no-restricted-globals": ["error", "name", "length"],
    "prefer-arrow-callback": "error",
    "quotes": ["error", "double", {"allowTemplateLiterals": true}],

    "indent": "off",
    "max-len": "off",
    "comma-dangle": "off",
    "no-unused-vars": ["error", {"argsIgnorePattern": "^_"}],
    "object-curly-spacing": "off",
    "no-trailing-spaces": "off",
    // DESACTIVAR ESTA REGLA PARA EVITAR EL ERROR DE EOL-LAST
    "eol-last": "off", // ¡CAMBIO AQUÍ!
  },
  overrides: [
    {
      files: ["**/*.spec.*"],
      env: {
        mocha: true,
      },
      rules: {},
    },
  ],
  globals: {},
};