module.exports = {
    testEnvironment: 'jest-environment-jsdom',
    setupFilesAfterEnv: [
    'jest-extended'
  ],
    moduleFileExtensions: ['js'],
    transform: {
        '^.+\\.js$': 'babel-jest',
    },
    roots: ['<rootDir>/spec'],
};
