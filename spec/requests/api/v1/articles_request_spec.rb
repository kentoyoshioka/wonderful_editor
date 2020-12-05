require "rails_helper"

RSpec.describe "Api::V1::Articles", type: :request do
  describe "GET /articles" do
    subject { get(api_v1_articles_path) }

    let!(:article1) { create(:article, status: :published, updated_at: 1.days.ago) }
    let!(:article2) { create(:article, status: :published, updated_at: 2.days.ago) }
    let!(:article3) { create(:article, status: :published) }
    let!(:article4) { create(:article, status: :draft) }

    it "公開設定の記事一覧の表示" do
      subject

      res = JSON.parse(response.body)
      expect(res.length).to eq(3)
      expect(response.status).to eq(200)
      expect(res.map {|h| h["id"] }).to eq [article3.id, article1.id, article2.id]
      expect(res[0].keys).to eq ["id", "title", "updated_at", "status", "user"]
      expect(res[0]["user"].keys).to eq ["id", "name", "email"]
    end
  end

  describe "GET /articles/:id" do
    subject { get(api_v1_article_path(article_id)) }

    context "指定した id の記事が存在し" do
      let(:article_id) { article.id }

      context "公開設定の記事の場合" do
        let(:article) { create(:article, status: :published) }

        it "公開設定の記事を取得する" do
          subject
          res = JSON.parse(response.body)

          expect(res["id"]).to eq article.id
          expect(res["title"]).to eq article.title
          expect(res["body"]).to eq article.body
          expect(res["updated_at"]).to be_present
          expect(res["status"]).to eq "published"
          expect(res["user"]["id"]).to eq article.user.id
          expect(res["user"].keys).to eq ["id", "name", "email"]
          expect(response.status).to eq(200)
        end
      end

      context "下書き状態の記事の場合" do
        let(:article) { create(:article, :draft) }

        it "記事が見つからない" do
          expect { subject }.to raise_error ActiveRecord::RecordNotFound
        end
      end
    end

    context "指定した id の記事が存在しない場合" do
      let(:article_id) { 1000000 }

      it "記事が見つからない" do
        expect { subject }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end

  describe "POST /articles" do
    subject { post(api_v1_articles_path, params: params, headers: headers) }

    let(:current_user) { create(:user) }
    let(:headers) { current_user.create_new_auth_token }

    context "公開設定で記事を作成する場合" do
      let(:params) { { article: attributes_for(:article, status: :published) } }

      it "公開設定の記事が作成される" do
        expect { subject }.to change { current_user.articles.count }.by(1)
        res = JSON.parse(response.body)
        expect(res["title"]).to eq params[:article][:title]
        expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "published"
        expect(response.status).to eq(200)
      end
    end

    context "下書き設定で記事を作成する場合" do
      let(:params) { { article: attributes_for(:article, status: :draft) } }

      it "下書き設定の記事が作成される" do
        # 模範　expect { subject }.to change { Article.count }.by(1)
        expect { subject }.to change { current_user.articles.count }.by(1)
        res = JSON.parse(response.body)
        # ↓　title,body に関してはどちらかなくても下書き保存できる？為なくても良い
        # expect(res["title"]).to eq params[:article][:title]
        # expect(res["body"]).to eq params[:article][:body]
        expect(res["status"]).to eq "draft"
        expect(response.status).to eq(200)
      end
    end

    # ↓　エラーテストの追加
    context "でたらめな指定で記事を作成する時" do
      let(:params) { { article: attributes_for(:article, status: :foo) } }

      fit "エラーになる" do
        expect { subject }.to raise_error(ArgumentError)
      end
    end
  end

  describe "PATCH /articles/:id" do
    subject { patch(api_v1_article_path(article.id), params: params, headers: headers) }

    let(:params) { { article: attributes_for(:article, status: :published) } }
    let(:current_user) { create(:user) }

    let(:headers) { current_user.create_new_auth_token }

    context "自分の記事を更新をする場合" do
      # 更新前の記事の作成
      let(:article) { create(:article, user: current_user, status: :draft) }

      it "任意の記事が更新される" do
        expect { subject }.to change { article.reload.title }.from(article.title).to(params[:article][:title]) &
                              change { article.reload.body }.from(article.body).to(params[:article][:body]) &
                              change { article.reload.status }.from(article.status).to(params[:article][:status].to_s) &
                              not_change { article.reload.created_at }
        expect(response.status).to eq(200)
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
