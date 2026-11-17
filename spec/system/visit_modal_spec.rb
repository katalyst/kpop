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

  it "refreshes a page that matches a modal rule as a page" do
    visit_root
    page.execute_script(<<~JS)
      history.replaceState(history.state, "", #{modal_path.to_json});
      Turbo.session.refresh(document.baseURI);
    JS

    expect(page).to have_no_css("body[data-marker]")
  end
end
