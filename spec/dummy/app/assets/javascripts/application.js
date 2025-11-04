import "controllers";
import "@hotwired/turbo-rails";

import kpop from "@katalyst/kpop";

kpop.configure({
  rules: [
    {
      patterns: ["^/modal"],
      properties: {
        context: "modal",
      }
    }
  ],
  debug: true,
}).start();
