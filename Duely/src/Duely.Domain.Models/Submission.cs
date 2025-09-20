namespace Duely.Domain.Models;

public sealed class Submission
{
    public int Id { get; set; }
    public int DuelId { get; set; }
    public int UserId { get; set; }
    public required string Code { get; set; }
    public required string Language { get; set; }
    public DateTime SubmitTime { get; set; }
    public required string Status { get; set; }      
    public required string Verdict { get; set; }

    public required Duel Duel { get; set; }
}