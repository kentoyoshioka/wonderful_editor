require "rails_helper"

RSpec.describe "Api::V1::Currents", type: :request do
  describe "GET /current/articles" do
    subject { get(api_v1_currents_path, headers: headers) }

    context "マイページにアクセスし" do
      let(:current_user) { create(:user) }
      let(:headers) { current_user.create_new_auth_token }

      context "自分の公開記事が存在する時" do
        let!(:article1) { create(:article, status: :published, user: current_user) }
        let!(:article2) { create(:article, status: :published) }
        let!(:article3) { create(:article, status: :draft, user: current_user) }

        it "自分の公開記事の一覧が取得出来る" do
          subject

          res = JSON.parse(response.body)
          expect(res.length).to eq(1)
          expect(response.status).to eq(200)
          expect(res[0]["status"]).to eq "published"
          expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
          expect(res[0]["user"].keys).to eq ["id", "name", "email"]
        end
      end
    end
  end
end
