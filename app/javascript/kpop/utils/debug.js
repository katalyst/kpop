let enabled = false;

const debug = function (receiver) {
  if (enabled) {
    return console.debug.bind(console, "[%s] %s", receiver);
  } else {
    return noop;
  }
};

const noop = () => {};

Object.defineProperty(debug, "enabled", {
  get: function () {
    return enabled;
  },
  set: function (debug) {
    enabled = debug;
  },
});

export default debug;
