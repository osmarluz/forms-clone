require 'rails_helper'

describe "GET /forms" do
  context "with invalid authentication headers" do
    it_behaves_like :deny_without_authorization, :get, "/api/v1/forms"
  end

  context "with valid authentication headers" do
    before do
      @user = create(:user)
      @form1 = create(:form, user: @user)
      @form2 = create(:form, user: @user)

      get "/api/v1/forms", params: {}, headers: header_with_authentication(@user)
    end

    it "returns success status (200)" do
      expect_status(200)
    end

    it "returns form list with 2 forms" do
      expect(json.count).to eql(2)
    end

    it "returns forms with correct data" do
      expect(json[0]).to eql(JSON.parse(@form1.to_json))
      expect(json[1]).to eql(JSON.parse(@form2.to_json))
    end
  end
end

describe "GET /forms/:friendly_id" do
  before do
    @user = create(:user)
  end

  context "when form exists" do

    context "and is enabled" do
      before do
        @form = create(:form, user: @user, enable: true)
        @question1 = create(:question, form: @form)
        @question2 = create(:question, form: @form)

        get "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
      end

      it "returns success status (200)" do
        expect_status(200)
      end

      it "returns form with correct data" do
        expect(json.except('questions')).to eql(JSON.parse(@form.to_json))
      end

      it "returns associated questions" do
        expect(json['questions'].first).to eql(JSON.parse(@question1.to_json))
        expect(json['questions'].last).to eql(JSON.parse(@question2.to_json))
      end
    end

    context "and is disabled" do
      before do
        @form = create(:form, user: @user, enable: false)
      end

      it "returns not found status (404)" do
        get "/api/v1/forms/#{FFaker::Lorem.word}", params: {id: @form.friendly_id}, headers: header_with_authentication(@user)
        expect_status(404)
      end
    end
  end

  context "when form doesn't exist" do
    it "returns not found status (404)" do
      get "/api/v1/forms/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
      expect_status(404)
    end
  end
end

describe "POST /forms" do

  context "with invalid authentication headers" do
    it_behaves_like :deny_without_authorization, :post, "/api/v1/forms"
  end

  context "with valid authentication headers" do
    before do
      @user = create(:user)
    end

    context "and with valid params" do
      before do
        @form_attributes = attributes_for(:form)
        post "/api/v1/forms", params: {form: @form_attributes}, headers: header_with_authentication(@user)
      end

      it "returns success status (200)" do
        expect_status(200)
      end

      it "creates form with correct data" do
        @form_attributes.each do |field|
          expect(Form.first[field.first]).to eql(field.last)
        end
      end

      it "returns correct form data" do
        @form_attributes.each do |field|
          expect(json[field.first.to_s]).to eql(field.last)
        end
      end
    end

    context "and with invalid params" do
      before do
        @other_user = create(:user)
        post "/api/v1/forms", params: {form: {}}, headers: header_with_authentication(@user)
      end

      it "returns bad request status (400)" do
        expect_status(400)
      end
    end
  end
end

describe "PUT /forms/:friendly_id" do

  context "with invalid authentication headers" do
    it_behaves_like :deny_without_authorization, :put, "/api/v1/forms/questionary"
  end

  context "with valid authentication headers" do
    before do
      @user = create(:user)
    end

    context "when form exists" do

      context "and user is the form owner" do
        before do
          @form = create(:form, user: @user)
          @form_attributes = attributes_for(:form, id: @form.id)
          put "/api/v1/forms/#{@form.friendly_id}", params: {form: @form_attributes}, headers: header_with_authentication(@user)
        end

        it "returns success status (200)" do
          expect_status(200)
        end

        it "updates form with correct data" do
          @form.reload
          @form_attributes.each do |field|
            expect(@form[field.first]).to eql(field.last)
          end
        end

        it "returns correct form data" do
          @form_attributes.each do |field|
            expect(json[field.first.to_s]).to eql(field.last)
          end
        end
      end

      context "and user is not the owner" do
        before do
          @form = create(:form)
          @form_attributes = attributes_for(:form, id: @form.id)
          put "/api/v1/forms/#{@form.friendly_id}", params: {form: @form_attributes}, headers: header_with_authentication(@user)
        end

        it "returns forbidden status (403)" do
          expect_status(403)
        end
      end
    end

    context "when form doesn't exist" do
      before do
        @form_attributes = attributes_for(:form)
      end

      it "returns not found status (404)" do
        delete "/api/v1/forms/#{FFaker::Lorem.word}", params: {form: @form_attributes}, headers: header_with_authentication(@user)
        expect_status(404)
      end
    end
  end
end

describe "DELETE /forms/:friendly_id" do
  before do
    @user = create(:user)
  end

  context "with invalid authentication headers" do
    it_behaves_like :deny_without_authorization, :delete, "/api/v1/forms/questionary"
  end

  context "with valid authentication headers" do

    context "when form exists" do

      context "and user is the owner" do
        before do
          @form = create(:form, user: @user)
          @question = create(:question, form: @form)
          delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
        end

        it "returns success status (200)" do
          expect_status(200)
        end

        it "deletes the form" do
          expect(Form.all.count).to eql(0)
        end

        it "deletes associated questions" do
          expect(Question.all.count).to eql(0)
        end
      end

      context "and user is not the owner" do
        before do
          @form = create(:form)
          delete "/api/v1/forms/#{@form.friendly_id}", params: {}, headers: header_with_authentication(@user)
        end

        it "returns forbidden status (403)" do
          expect_status(403)
        end
      end
    end

    context "when form doesn't exist" do
      it "returns not found status 404" do
        delete "/api/v1/forms/#{FFaker::Lorem.word}", params: {}, headers: header_with_authentication(@user)
        expect_status(404)
      end
    end
  end
end
