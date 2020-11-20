require "rails_helper"

RSpec.describe "Api::V1::Auth::Registrations", type: :request do
  describe "POST api/v1/auth" do
    subject { post(api_v1_user_registration_path, params: params) }

    context "name, email, password に値が正常に入っている時" do
      let(:params) { attributes_for(:user) }

      it "ユーザーが作成される" do
        expect { subject }.to change { User.count }.by(1)
        expect(response).to have_http_status(:ok)
      end

      it "header の情報が送られる" do
        subject
        header = response.header
        expect(header["access-token"]).to be_present
        expect(header["client"]).to be_present
        expect(header["expiry"]).to be_present
        expect(header["uid"]).to be_present
        expect(header["token-type"]).to be_present
      end
    end

    context "入力した値が既に使用されている時" do
      let(:params) { attributes_for(:user, email: "example@email.com") }
      let!(:other_user) { create(:user, email: "example@email.com") }

      it "ユーザー登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        json = JSON.parse(response.body)
        expect(json["data"]["email"]).to eq(other_user.email)
        expect(response.status).to eq(422)
      end
    end

    context "name が存在しない時" do
      let(:params) { attributes_for(:user, name: nil) }

      it "ユーザーの新規登録に失敗する" do
        # binding.pry
        expect { subject }.to change { User.count }.by(0)
        json = JSON.parse(response.body)
        expect(response.status).to eq(422)
        expect(json["data"]["name"]).to eq(nil)
      end
    end

    context "email が存在しない時" do
      let(:params) { attributes_for(:user, email: nil) }

      it "ユーザーの新規登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        json = JSON.parse(response.body)
        expect(response.status).to eq(422)
        expect(json["data"]["email"]).to eq(nil)
      end
    end

    context "password が存在しない時" do
      let(:params) { attributes_for(:user, password: nil) }

      it "ユーザーの新規登録に失敗する" do
        expect { subject }.to change { User.count }.by(0)
        json = JSON.parse(response.body)
        expect(response.status).to eq(422)
        expect(json["data"]["password"]).to eq(nil)
      end
    end
  end
end
