using System.Reflection;
using Duely.Infrastructure.DataAccess.Abstracts;
using Microsoft.EntityFrameworkCore;

namespace Duely.Infrastructure.DataAccess.EntityFramework;

public sealed class UnitOfWork : DbContext, IUnitOfWork
{
    public UnitOfWork(DbContextOptions<UnitOfWork> options) : base(options)
    {
    }
    
    public new async Task<int> SaveChangesAsync(CancellationToken cancellationToken)
    {
        return await base.SaveChangesAsync(cancellationToken);
    }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}