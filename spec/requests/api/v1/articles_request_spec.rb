require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, updated_at: 2.days.ago) }
    let!(:article3) { create(:article) }

    it "記事一覧の表示" do
      subject

      res = JSON.parse(response.body)
      # binding.pry
      expect(res.length).to eq(3)
      expect(response.status).to eq(200)
      expect(res.map {|h| h["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在する場合" do
      let(:article_id) { article.id }
      let(:article) { create(:article) }

      it "記事のタイトル、内容を取得する" do
        subject

        res = JSON.parse(response.body)

        expect(res["id"]).to eq article.id
        expect(res["title"]).to eq article.title
        expect(res["body"]).to eq article.body
        expect(res["updated_at"]).to be_present
        # binding.pry
        expect(res["user"]["id"]).to eq article.user.id
        expect(res["user"].keys).to eq ["id", "name", "email"]
        expect(response.status).to eq(200)
      end
    end

    context "指定した id の記事が存在しない場合" do
      let(:article_id) { 1_000_000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error ActiveRecord::RecordNotFound
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    context "title, bodyに値が存在する場合" do
      let(:params) { { article: attributes_for(:article) } }
      let(:current_user) { create(:user) }

      let(:headers) { current_user.create_new_auth_token }

      it "記事が作成される" do
        expect { subject }.to change { Article.where(user_id: current_user.id).count }.by(1)

        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(response.status).to eq(200)
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article) } }
    let(:current_user) { create(:user) }

    let(:headers) { current_user.create_new_auth_token }

    context "title, bodyに値が存在する場合" do
      let(:article) { create(:article, user: current_user) }

      it "任意の記事が更新される" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              not_change { article.reload.created_at }
        expect(response.status).to eq(200)
        # json = JSON.parse(response.body)
      end
    end

    context "自分が所持していない記事のレコードを更新しようとするとき" do
      let(:other_user) { create(:user) }
      let!(:article) { create(:article, user: other_user) }

      it "更新できない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end

  describe "DELETE /articles/:id" do
    subject { delete(api_v1_article_path(article.id), headers: headers) }

    let(:current_user) { create(:user) }

    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を削除する場合" do
      let!(:article) { create(:article, user: current_user) }

      it "指定のレコードが削除される" do
        expect { subject }.to change { Article.count }.by(-1)
      end
    end

    context "自分以外の記事を削除する場合" do
      let!(:article) { create(:article, user: other_user) }
      let(:other_user) { create(:user) }
      it "記事の削除に失敗する" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound) &
                              change { Article.count }.by(0)
      end
    end
  end
end
