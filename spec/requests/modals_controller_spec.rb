# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalsController do
  subject { action && response }

  describe "GET /modal/anonymous" do
    let(:action) { get anonymous_modal_path }

    it { is_expected.to redirect_to(root_path) }

    context "with kpop frame request" do
      let(:action) { get anonymous_modal_path, headers: { "Turbo-Frame" => "kpop" } }

      it { is_expected.to be_successful }
      it { is_expected.to render_kpop_frame }
      it { is_expected.to render_kpop_frame(title: "Anonymous modal") }
    end

    context "with turbo stream request" do
      let(:action) { get anonymous_modal_path, as: :turbo_stream }

      it { is_expected.to be_successful }
      it { is_expected.to render_kpop_stream }
      it { is_expected.to render_kpop_stream(title: /Anonymous/) }
    end
  end

  describe "PATCH /modal" do
    let(:action) { patch modal_path }

    it { is_expected.to redirect_to(root_path) }

    context "with turbo stream request" do
      let(:action) { patch modal_path, as: :turbo_stream }

      it { is_expected.to kpop_redirect_to(root_path) }
    end
  end
end
