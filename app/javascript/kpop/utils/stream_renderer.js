import DEBUG from "../debug";

export class StreamRenderer {
  constructor(frame, action) {
    this.frame = frame;
    this.action = action;
  }

  render() {
    if (DEBUG) console.debug("stream-renderer:render");
    this.frame.src = "";
    this.frame.innerHTML = "";
    this.frame.append(this.action.templateContent);
  }
}
