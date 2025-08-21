defmodule Matching.MatchingEngine do
  import Ecto.Query
  alias Matching.Repo
  alias Matching.Accounts.User

  # Règles de compatibilité ABO
  def abo_compatible?(recipient_abo, donor_abo) do
    case recipient_abo do
      # O peut recevoir seulement de O
      "O" -> donor_abo == "O"
      # A peut recevoir de O et A
      "A" -> donor_abo in ["O", "A"]
      # B peut recevoir de O et B
      "B" -> donor_abo in ["O", "B"]
      # AB peut recevoir de tous
      "AB" -> donor_abo in ["O", "A", "B", "AB"]
    end
  end

  # Règles de compatibilité Rh
  def rh_compatible?(recipient_rh, donor_rh) do
    case recipient_rh do
      # Rh- peut recevoir seulement de Rh-
      "-" -> donor_rh == "-"
      # Rh+ peut recevoir de Rh- et Rh+
      "+" -> donor_rh in ["-", "+"]
    end
  end

  def blood_compatible?(recipient, donor) do
    abo_compatible?(recipient.abo, donor.abo) and
      rh_compatible?(recipient.rh, donor.rh)
  end

  def eligible_pair?(reference, candidate) do
    ref_ok = reference.role in [:recipient, :both]
    cand_ok = candidate.role in [:donor, :both]
    ref_ok and cand_ok
  end

  def filter_candidates(reference, candidates) do
    Enum.filter(candidates, fn candidate ->
      eligible_pair?(reference, candidate) and
        blood_compatible?(reference, candidate)
    end)
  end

  def trait_score(u1, u2) do
    t1 = Enum.map(u1.traits, & &1.id)
    t2 = Enum.map(u2.traits, & &1.id)
    length(Enum.filter(t1, fn id -> id in t2 end))
  end

  def canton_bonus(u1, u2) do
    if u1.canton == u2.canton, do: 1, else: 0
  end

  def score_candidates(reference, candidates) do
    candidates
    |> Enum.map(fn candidate ->
      score = trait_score(reference, candidate) + canton_bonus(reference, candidate)
      Map.put(candidate, :score_total, score)
    end)
    |> Enum.sort_by(& &1.score_total, :desc)
  end

  def match(reference) do
    candidates =
      from(u in User,
        where: u.id != ^reference.id and u.role in ^[:donor, :both],
        preload: [:traits]
      )
      |> Repo.all()

    filtered = filter_candidates(reference, candidates)
    score_candidates(reference, filtered)
  end

  def run(reference_id) do
    reference = Repo.get!(User, reference_id) |> Repo.preload(:traits)
    match(reference)
  end
end
