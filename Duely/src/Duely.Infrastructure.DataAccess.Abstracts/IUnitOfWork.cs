namespace Duely.Infrastructure.DataAccess.Abstracts;

public interface IUnitOfWork
{
    Task<int> SaveChangesAsync(CancellationToken cancellationToken);
}