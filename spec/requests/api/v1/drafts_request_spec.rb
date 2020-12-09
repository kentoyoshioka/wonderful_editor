require "rails_helper"

RSpec.describe "Api::V1::Articles::Drafts", type: :request do
  # ログインのユーザー
  let(:current_user) { create(:user) }
  let(:headers) { current_user.create_new_auth_token }

  describe "GET /drafts" do
    subject { get(api_v1_articles_drafts_path, headers: headers) }

    context "自分の下書き記事が存在する時" do
      let!(:article1) { create(:article, status: :draft, user: current_user) }
      let!(:article2) { create(:article, status: :draft) }
      let!(:article3) { create(:article, status: :published, user: current_user) }

      it "自分の下書き一覧が取得できる" do
        subject
        res = JSON.parse(response.body)
        # binding.pry
        expect(res.length).to eq(1)
        expect(response.status).to eq(200)
        expect(res[0]["id"]).to eq article1.id
        expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
        expect(res[0]["user"].keys).to eq ["id", "name", "email"]
      end
    end
  end

  describe "GET /drafts/:id" do
    subject { get(api_v1_articles_draft_path(article_id), headers: headers) }

    context "指定した id の記事が存在し" do
      let(:article_id) { article.id }

      context "自分の下書き記事の詳細を取得する時" do
        let(:article) { create(:article, status: :draft, user: current_user) }

        it "自分の下書きの詳細が取得できる" do
          subject
          res = JSON.parse(response.body)

          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res["status"]).to eq "draft"
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
          expect(response.status).to eq(200)
        end
      end

      context "自分の以外の下書き記事の詳細を取得する時" do
        let(:other_user) { create(:user) }
        let(:article) { create(:article, status: :draft, user: other_user) }

        it "エラーになる" do
          expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
        end
      end
    end
  end
end
