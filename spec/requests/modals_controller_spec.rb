# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalsController do
  subject { action && response }

  describe "GET /modal" do
    let(:action) { get modal_path }

    it { is_expected.to be_successful }
    it { is_expected.to have_rendered("home/index") }
    it { is_expected.to have_rendered("modals/content") }

    context "with turbo frame" do
      let(:action) { get modal_path, headers: { "Turbo-Frame" => "kpop" } }

      it { is_expected.to be_successful }
      it { is_expected.to have_rendered("layouts/kpop/frame") }
      it { is_expected.to have_rendered("modals/frame") }
    end
  end

  describe "PATCH /modal" do
    let(:action) { patch modal_path, as: :turbo_stream }

    it { is_expected.to be_successful }
    it { is_expected.to render_kpop_stream }
    it { is_expected.to render_kpop_stream(title: "Stream modal") }

    context "with home as html" do
      let(:action) { patch modal_path, params: { next: "home" } }

      it { is_expected.to redirect_to(root_path) }
    end

    context "with test as html" do
      let(:action) { patch modal_path, params: { next: "test" } }

      it { is_expected.to redirect_to(test_path) }
    end

    context "with home as turbo" do
      let(:action) { patch modal_path, params: { next: "home" }, as: :turbo_stream }

      it { is_expected.to kpop_dismiss }
    end

    context "with test as turbo" do
      let(:action) { patch modal_path, params: { next: "test" }, as: :turbo_stream }

      it { is_expected.to kpop_redirect_to(test_path) }
    end

    context "with error as turbo" do
      let(:action) { patch modal_path, params: { next: "error", template: "anonymous" }, as: :turbo_stream }

      it { is_expected.to have_http_status(:unprocessable_entity) }
      it { is_expected.to have_rendered("modals/update") }
      it { is_expected.to have_rendered("modals/_form") }
    end
  end
end
