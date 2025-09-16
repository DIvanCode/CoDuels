namespace Duely.Infrastructure.DataAccess.Abstracts;

public interface IBaseRepository<in TEntity> where TEntity : class
{
    void Add(TEntity entity);
    void Update(TEntity entity);
    void Remove(TEntity entity);
}