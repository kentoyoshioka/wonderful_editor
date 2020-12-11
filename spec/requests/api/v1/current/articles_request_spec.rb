require "rails_helper"

RSpec.describe "Api::V1::Current::Articles", type: :request do
  describe "GET /current/articles" do
    subject { get(api_v1_current_articles_path, headers: headers) }

    # 現在のユーザーを作成し、tokenを発行
    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "複数の記事が存在する時" do
      # いくつかの記事を作成
      let!(:article1) { create(:article, status: :published, user: current_user, updated_at: 1.day.ago) }
      let!(:article2) { create(:article, status: :published, user: current_user, updated_at: 2.days.ago) }
      let!(:article3) { create(:article, status: :published, user: current_user) }

      before do
        # let を定義し過ぎると rubocop でエラーが出るので before にて定義
        # 現在のユーザーの下書き記事と他のユーザーの公開記事
        create(:article, status: :draft, user: current_user)
        create(:article, status: :published)
      end

      it "自分の書いた公開記事を更新順に取得出来る" do
        subject

        res = JSON.parse(response.body)
        expect(res.length).to eq 3
        expect(res.map {|d| d["id"] }).to eq [article3.id, article1.id, article2.id]
        expect(res[0]["user"]["id"]).to eq current_user.id
        expect(res[0]["user"]["name"]).to eq current_user.name
        expect(res[0]["user"]["email"]).to eq current_user.email
        expect(response).to have_http_status(:ok)
      end
    end
  end
end
