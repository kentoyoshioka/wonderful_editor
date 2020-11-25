require "rails_helper"

RSpec.describe "Api::V1::Auth::Sesseions", type: :request do
  describe "POST api/v1/auth/sign_in" do
    subject { post(api_v1_user_session_path, params: params) }

    context "登録済の user の情報が送信された時" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: user.password) }

      it "ログインに成功する" do
        subject
        # binding.pry
        # res = JSON.parse(response.body)
        # expect(res["data"]["email"]).to eq(user.email)
        # expect(res["data"]["password"]).to eq(params.password)
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["uid"]).to be_present
        # expect(header["expiry"]).to be_present
        # expect(header["token-type"]).to be_present
        expect(response).to have_http_status(:ok)
      end
    end

    context "登録されていない user 情報が送られてきた時" do
      let!(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "test@email.com", password: "passtest") }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."

        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "email の情報が一致しない時" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: "test@email.com", password: user.password) }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."

        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank

        expect(response).to have_http_status(:unauthorized)
      end
    end

    context "password の情報が一致しない時" do
      let(:user) { create(:user) }
      let(:params) { attributes_for(:user, email: user.email, password: "passtest") }

      it "ログインに失敗する" do
        subject
        res = JSON.parse(response.body)
        expect(res["errors"]).to include "Invalid login credentials. Please try again."

        header = response.header
        expect(header["access-token"]).to be_blank
        expect(header["client"]).to be_blank
        expect(header["uid"]).to be_blank

        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
