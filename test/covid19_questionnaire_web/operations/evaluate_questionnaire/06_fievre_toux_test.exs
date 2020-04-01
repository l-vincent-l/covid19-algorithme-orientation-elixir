defmodule Covid19QuestionnaireWeb.Operations.EvaluateQuestionnaire.FievreTouxTest do
  @moduledoc """
  Patient avec fièvre + toux.
  """

  use ExUnit.Case, async: true
  alias Covid19Questionnaire.Tests.Conditions
  alias Covid19QuestionnaireWeb.Operations.EvaluateQuestionnaire
  alias Covid19QuestionnaireWeb.Schemas.{Pronostiques, Questionnaire, Symptomes}

  setup do
    {:ok,
     questionnaire: %Questionnaire{
       symptomes: %Symptomes{
         temperature: 37.8,
         cough: true
       },
       pronostiques: %Pronostiques{heart_disease: false}
     }}
  end

  describe "tout patient sans facteur pronostique" do
    test "sans facteur de gravité", %{questionnaire: questionnaire} do
      {:ok, questionnaire} =
        questionnaire
        |> EvaluateQuestionnaire.call()

      assert Conditions.symptomes2(questionnaire)
      assert Conditions.facteurs_pronostique(questionnaire) == 0
      assert Conditions.facteurs_gravite_mineurs(questionnaire) == 0
      assert Conditions.facteurs_gravite_majeurs(questionnaire) == 0
      assert questionnaire.conclusion.code == "FIN6"
    end

    test "avec au moins un facteur de gravité mineur sans facteur de gravité majeur", %{
      questionnaire: questionnaire
    } do
      {:ok, questionnaire} =
        %Questionnaire{
          questionnaire
          | symptomes: %Symptomes{questionnaire.symptomes | tiredness: true}
        }
        |> EvaluateQuestionnaire.call()

      assert Conditions.symptomes2(questionnaire)
      assert Conditions.facteurs_pronostique(questionnaire) == 0
      assert Conditions.facteurs_gravite_mineurs(questionnaire) >= 1
      assert Conditions.facteurs_gravite_majeurs(questionnaire) == 0
      assert questionnaire.conclusion.code == "FIN6"
    end
  end

  describe "tout patient avec un facteur pronostique ou plus" do
    test "aucun facteur de gravité", %{questionnaire: questionnaire} do
      {:ok, questionnaire} =
        %Questionnaire{
          questionnaire
          | pronostiques: %Pronostiques{questionnaire.pronostiques | heart_disease: true}
        }
        |> EvaluateQuestionnaire.call()

      assert Conditions.symptomes2(questionnaire)
      assert Conditions.facteurs_pronostique(questionnaire) >= 1
      assert Conditions.facteurs_gravite_mineurs(questionnaire) == 0
      assert Conditions.facteurs_gravite_majeurs(questionnaire) == 0
      assert questionnaire.conclusion.code == "FIN6"
    end

    test "un seul facteur de gravité mineur", %{questionnaire: questionnaire} do
      {:ok, questionnaire} =
        %Questionnaire{
          questionnaire
          | symptomes: %Symptomes{questionnaire.symptomes | tiredness: true},
            pronostiques: %Pronostiques{questionnaire.pronostiques | heart_disease: true}
        }
        |> EvaluateQuestionnaire.call()

      assert Conditions.symptomes2(questionnaire)
      assert Conditions.facteurs_pronostique(questionnaire) >= 1
      assert Conditions.facteurs_gravite_mineurs(questionnaire) == 1
      assert Conditions.facteurs_gravite_majeurs(questionnaire) == 0
      assert questionnaire.conclusion.code == "FIN6"
    end

    test "les deux facteurs de gravité mineurs", %{questionnaire: questionnaire} do
      {:ok, questionnaire} =
        %Questionnaire{
          questionnaire
          | symptomes: %Symptomes{questionnaire.symptomes | temperature: 39.0, tiredness: true},
            pronostiques: %Pronostiques{questionnaire.pronostiques | heart_disease: true}
        }
        |> EvaluateQuestionnaire.call()

      assert Conditions.symptomes2(questionnaire)
      assert Conditions.facteurs_pronostique(questionnaire) >= 1
      assert Conditions.facteurs_gravite_mineurs(questionnaire) == 2
      assert Conditions.facteurs_gravite_majeurs(questionnaire) == 0
      assert questionnaire.conclusion.code == "FIN4"
    end
  end

  test "tout patient avec ou sans facteur pronostique avec au moins un facteur de gravité majeur",
       %{questionnaire: questionnaire} do
    {:ok, questionnaire} =
      %Questionnaire{
        questionnaire
        | symptomes: %Symptomes{questionnaire.symptomes | breathlessness: true}
      }
      |> EvaluateQuestionnaire.call()

    assert Conditions.symptomes2(questionnaire)
    assert Conditions.facteurs_pronostique(questionnaire) == 0
    assert Conditions.facteurs_gravite_mineurs(questionnaire) == 0
    assert Conditions.facteurs_gravite_majeurs(questionnaire) >= 1
    assert questionnaire.conclusion.code == "FIN5"
  end
end
