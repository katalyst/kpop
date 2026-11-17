# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Modal opened by Turbo.visit" do
  include KpopMatchers

  def visit_root
    visit root_path
    page.driver.browser.network.wait_for_idle

    # A page render replaces the body, so the marker shows whether the page stayed
    page.execute_script("document.body.dataset.marker = ''")
  end

  def turbo_visit(path)
    page.execute_script("Turbo.visit(#{path.to_json})")
  end

  it "opens a location that matches a modal rule in the modal" do
    visit_root
    turbo_visit(modal_path)

    expect(page).to have_modal("Hello modal!")

    aggregate_failures do
      expect(page).to have_current_path(root_path)
      expect(page).to have_css("body[data-marker]")
      expect(frame).to have_src(modal_path)
    end
  end

  it "visits a location that matches no modal rule as a page" do
    visit_root
    turbo_visit(test_path)

    expect(page).to have_current_path(test_path)

    aggregate_failures do
      expect(page).to have_no_css("body[data-marker]")
      expect(page).to have_no_modal
    end
  end

  it "visits a modal location as a page when the page has no kpop frame" do
    visit_root
    page.execute_script("document.getElementById('kpop').remove()")
    turbo_visit(modal_path)

    # The page renders, rather than Turbo.visit proposing the visit forever
    expect(page).to have_no_css("body[data-marker]")
  end

  def append_link(text, **data)
    page.execute_script(<<~JS)
      const link = document.createElement("a");
      link.href = #{modal_path.to_json};
      Object.assign(link.dataset, #{data.to_json});
      link.textContent = #{text.to_json};
      document.body.append(link);
    JS
  end

  it "opens a modal location in the modal from a link that targets _top" do
    visit_root
    append_link("Top modal", turboFrame: "_top")

    click_link("Top modal")

    expect(page).to have_modal("Hello modal!")

    aggregate_failures do
      expect(page).to have_css("body[data-marker]")
      expect(frame).to have_src(modal_path)
    end
  end

  it "replaces an open modal with another modal location" do
    visit_root
    turbo_visit(modal_path)
    expect(page).to have_modal("Hello modal!")

    turbo_visit(modal_path(name: "other"))

    expect(page).to have_modal("Hello other modal!")

    aggregate_failures do
      expect(page).to have_current_path(root_path)
      expect(page).to have_css("body[data-marker]")
      expect(frame).to have_src(modal_path(name: "other"))
    end
  end

  it "reloads an open modal in place when visiting its location" do
    visit_root
    turbo_visit(modal_path)
    expect(page).to have_modal("Hello modal!")

    page.execute_script(<<~JS)
      const frame = document.getElementById("kpop");
      frame.querySelector("dialog").dataset.marker = "";
      window.kpopEvents = [];
      new MutationObserver((records) => {
        for (const { target, attributeName } of records) {
          if (target.hasAttribute(attributeName)) kpopEvents.push(attributeName);
        }
      }).observe(frame, { subtree: true, attributes: true, attributeFilter: ["animate"] });
      // Sample before each paint, so microtasks between render and open don't count
      (function check() {
        if (!frame.querySelector("dialog[open]")) kpopEvents.push("closed");
        requestAnimationFrame(check);
      })();
    JS
    turbo_visit(modal_path)

    # The dialog is new, so the modal reloaded
    expect(page).to have_css("dialog[open]:not([data-marker])")

    aggregate_failures do
      expect(page).to have_modal("Hello modal!")
      expect(page.evaluate_script("kpopEvents")).to be_empty
    end
  end

  it "closes an open modal when visiting a page" do
    visit_root
    turbo_visit(modal_path)
    expect(page).to have_modal("Hello modal!")

    turbo_visit(test_path)

    expect(page).to have_current_path(test_path)
    expect(page).to have_no_modal
  end

  it "cancels a loading modal when visiting a page" do
    visit_root

    # Visiting in one script means the modal is still loading
    page.execute_script(<<~JS)
      Turbo.visit(#{modal_path.to_json});
      Turbo.visit(#{test_path.to_json});
    JS
    expect(page).to have_current_path(test_path)

    # Restoring the cached root page should not reload the cancelled modal
    page.go_back
    expect(page).to have_text("Hello world!")
    page.driver.browser.network.wait_for_idle
    expect(page).to have_no_modal
  end

  it "keeps an open modal when a page visit is cancelled" do
    visit_root
    turbo_visit(modal_path)
    expect(page).to have_modal("Hello modal!")

    page.execute_script(<<~JS)
      addEventListener("turbo:before-visit", (e) => e.preventDefault(), { once: true });
    JS
    turbo_visit(test_path)

    expect(page).to have_current_path(root_path)
    expect(page).to have_modal("Hello modal!")
  end

  it "refreshes a page that matches a modal rule as a page" do
    visit_root
    page.execute_script(<<~JS)
      history.replaceState(history.state, "", #{modal_path.to_json});
      Turbo.session.refresh(document.baseURI);
    JS

    expect(page).to have_no_css("body[data-marker]")
  end
end
