namespace Duely.Domain.Models;

public sealed class Duel
{
    public int Id { get; set; }
    public required string TaskId { get; set; }
    public int User1Id { get; set; }
    public int User2Id { get; set; }
    public required string Status { get; set; }
    public required string Result { get; set; }
    public DateTime StartTime { get; set; }
    public DateTime EndTime { get; set; }
    public int MaxDuration { get; set; } = 30;
    public ICollection<Submission> Submissions{ get; set; } = new List<Submission>();
}