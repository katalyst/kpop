/**
 * Similar to Hotwire's PathConfiguration.json, this class compiles a list of
 * rules to check link hrefs against so that we can identify links that
 * should open in a KPOP modal.
 *
 * Unlike Hotwire Native, we can't intercept 303s in the browser before they
 * load. Browser sandbox prevents us from inspecting the location of redirect
 * requests so we can only intercept links that match modals directly.
 *
 * For posts and redirects, we need server support (flash modals, streams).
 */
export default class Ruleset {
  constructor(rules = []) {
    this.rules = [];

    rules.forEach((rule) => {
      this.#compileRule(rule);
    });
  }

  /**
   * Returns properties for the given URL
   *
   * @param {URL} location
   * @returns {} properties
   */
  properties(location) {
    return this.rules.reduce((c, f) => f(location, c), {});
  }

  #compileRule({ patterns, properties }) {
    patterns.forEach((pattern) => {
      this.rules.push(locationMatcher(new RegExp(pattern), properties));
    });
  }
}

function locationMatcher(re, properties) {
  return (location, accumulator) =>
    re.test(location.pathname)
      ? { ...accumulator, ...properties }
      : accumulator;
}
