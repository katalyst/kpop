# frozen_string_literal: true

require "rails_helper"

RSpec.describe ModalsController do
  subject(:result) { action && response }

  describe "GET /modal" do
    context "with browser navigation" do
      let(:action) { get modal_path }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(root_path)) }

      it "stores the modal location in flash" do
        action
        expect(flash[:modal_location]).to eq("/modal")
      end

      it "shows the modal after redirect" do
        action
        follow_redirect!
        expect(response).to have_kpop_src("/modal")
      end
    end

    context "with kpop frame" do
      let(:action) { get modal_path, headers: { "Turbo-Frame" => "kpop" } }

      it { is_expected.to be_successful }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/kpop/frame") }
    end

    context "with native app" do
      let(:action) { get modal_path, headers: { "User-Agent" => "Hotwire Native" } }

      it { is_expected.to be_successful }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/hotwire") }
    end

    # testing fallback situation where kpop did not set data-turbo-frame
    context "with turbo stream (fallback)" do
      let(:action) { get modal_path, as: :turbo_stream }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(root_path)) }

      it "stores the modal location in flash" do
        action
        expect(flash[:modal_location]).to eq("/modal")
      end

      it "shows the modal after redirect" do
        action
        follow_redirect!(as: :turbo_stream)
        expect(response).to have_kpop_src("/modal")
      end
    end
  end

  describe "PATCH /modal?next=close" do
    context "with bare form" do
      let(:action) { post modal_path, params: { _method: "patch", next: "close" } }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(root_path)) }

      it "does not store flash" do
        action
        expect(flash[:modal_location]).to be_nil
      end
    end

    context "with kpop request" do
      let(:action) { patch modal_path, params: { next: "close" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: root_url,
          "Kpop-Available" => "true",
        }
      end

      it { is_expected.to redirect_to(turbo_resume_historical_location_path) }
    end

    context "with native app" do
      let(:action) { patch modal_path, params: { next: "close" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: modal_url,
          "User-Agent" => "Hotwire Native",
        }
      end

      it { is_expected.to redirect_to(turbo_resume_historical_location_path) }
    end

    # testing fallback situation where the kpop header is missing
    context "with turbo stream (fallback)" do
      let(:action) do
        patch modal_path, params: { next: "close" }, as: :turbo_stream
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(root_path)) }

      it "does not store flash" do
        action
        expect(flash[:modal_location]).to be_nil
      end
    end
  end

  describe "PATCH /modal?next=error" do
    context "with bare form" do
      let(:action) { post modal_path, params: { _method: "patch", next: "error" } }

      it { is_expected.to have_http_status(:unprocessable_content) }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/application") }
    end

    context "with kpop request" do
      let(:action) { patch modal_path, params: { next: "error" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: root_url,
          "Kpop-Available" => "true",
        }
      end

      it { is_expected.to have_http_status(:unprocessable_content) }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/kpop/stream") }

      it "changes the response type to turbo-stream" do
        action
        expect(response.headers).to include("content-type" => "text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "wraps the response in turbo-stream.kpop_open" do
        action
        expect(response.body).to match(/^<turbo-stream action="kpop_open"/)
      end
    end

    context "with native app" do
      let(:action) { patch modal_path, params: { next: "error" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: modal_url,
          "User-Agent" => "Hotwire Native",
        }
      end

      it { is_expected.to have_http_status(:unprocessable_content) }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/hotwire") }
    end

    # testing fallback situation where the kpop header is missing
    context "with turbo stream (fallback)" do
      let(:action) do
        patch modal_path, params: { next: "error" }, as: :turbo_stream
      end

      it { is_expected.to have_http_status(:unprocessable_content) }
      it { is_expected.to have_rendered("modals/show") }
      it { is_expected.to have_rendered("layouts/application") }
    end
  end

  describe "PATCH /modal?next=page" do
    context "with bare form" do
      let(:action) { post modal_path, params: { _method: "patch", next: "page" } }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(test_path)) }
    end

    context "with kpop request" do
      let(:action) { patch modal_path, params: { next: "page" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: root_url,
          "Kpop-Available" => "true",
        }
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(test_path)) }
    end

    context "with native app" do
      let(:action) { patch modal_path, params: { next: "page" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: modal_url,
          "User-Agent" => "Hotwire Native",
        }
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(test_path)) }
    end

    # testing fallback situation where the kpop header is missing
    context "with turbo stream (fallback)" do
      let(:action) do
        patch modal_path, params: { next: "page" }, as: :turbo_stream
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(test_path)) }
    end
  end

  describe "PATCH /modal?next=modal" do
    context "with bare form" do
      let(:action) { post modal_path, params: { _method: "patch", next: "modal" } }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(modal_path(name: "update"))) }

      it "stores the modal location in flash" do
        action
        follow_redirect!(headers: { HTTP_REFERER: root_url })
        expect(flash[:modal_location]).to eq("/modal?name=update")
      end

      it "loads the modal via turbo-frame after redirect" do
        action
        follow_redirect!(headers: { HTTP_REFERER: root_url }) # /modal?name=update
        follow_redirect! # /root
        expect(response).to have_kpop_src("/modal?name=update")
      end
    end

    context "with kpop request" do
      let(:action) { patch modal_path, params: { next: "modal" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: root_url,
          "Kpop-Available" => "true",
        }
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(modal_path(name: "update"))) }

      it "renders the modal without redirecting again" do
        action
        follow_redirect!(headers:, as: :turbo_stream)
        expect(response).to have_rendered("modals/show").and(have_rendered("layouts/kpop/stream"))
      end
    end

    context "with native app" do
      let(:action) { patch modal_path, params: { next: "modal" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: modal_url,
          "User-Agent" => "Hotwire Native",
        }
      end

      it { is_expected.to have_http_status(:see_other).and(redirect_to(modal_path(name: "update"))) }

      it "renders the modal without redirecting again" do
        action
        follow_redirect!(headers:, as: :turbo_stream)
        expect(response).to have_rendered("modals/show").and(have_rendered("layouts/hotwire"))
      end
    end

    # testing fallback situation where the kpop header is missing
    context "with turbo stream (fallback)" do
      let(:action) { patch modal_path, params: { next: "modal" }, as: :turbo_stream }

      it { is_expected.to have_http_status(:see_other).and(redirect_to(modal_path(name: "update"))) }

      it "stores the modal location in flash" do
        action
        follow_redirect!(headers: { HTTP_REFERER: root_url }, as: :turbo_stream)
        expect(flash[:modal_location]).to eq("/modal?name=update")
      end

      it "shows the modal after redirect" do
        action
        follow_redirect!(headers: { HTTP_REFERER: root_url }, as: :turbo_stream)
        follow_redirect!(headers: { HTTP_REFERER: root_url }, as: :turbo_stream)
        expect(response).to have_kpop_src("/modal?name=update")
      end
    end
  end

  describe "PATCH /modal?next=stream" do
    context "with bare form" do
      let(:action) do
        post modal_path, params: { _method: "patch", next: "stream" }, headers: { "Accept" => "text/html" }
      end

      it { is_expected.to have_http_status(:not_acceptable) }
    end

    context "with kpop request" do
      let(:action) { patch modal_path, params: { next: "stream" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: root_url,
          "Kpop-Available" => "true",
        }
      end

      it { is_expected.to have_http_status(:ok) }

      it "returns the turbo-stream" do
        action
        expect(response.headers).to include("content-type" => "text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "does not render the kpop layout" do
        action
        expect(response.body).to match(/^<turbo-stream action="replace"/)
      end
    end

    context "with native app" do
      let(:action) { patch modal_path, params: { next: "stream" }, as: :turbo_stream, headers: }
      let(:headers) do
        {
          HTTP_REFERER: modal_url,
          "User-Agent" => "Hotwire Native",
        }
      end

      it { is_expected.to have_http_status(:ok) }

      it "returns the turbo-stream" do
        action
        expect(response.headers).to include("content-type" => "text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "does not render the kpop layout" do
        action
        expect(response.body).to match(/^<turbo-stream action="replace"/)
      end
    end

    # testing fallback situation where the kpop header is missing
    context "with turbo stream (fallback)" do
      let(:action) do
        patch modal_path, params: { next: "stream" }, as: :turbo_stream
      end

      it { is_expected.to have_http_status(:ok) }

      it "returns the turbo-stream" do
        action
        expect(response.headers).to include("content-type" => "text/vnd.turbo-stream.html; charset=utf-8")
      end

      it "does not render the kpop layout" do
        action
        expect(response.body).to match(/^<turbo-stream action="replace"/)
      end
    end
  end
end
