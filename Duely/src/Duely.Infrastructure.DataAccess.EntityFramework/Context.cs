using System.Reflection;
using Microsoft.EntityFrameworkCore;

namespace Duely.Infrastructure.DataAccess.EntityFramework;

public sealed class Context : DbContext
{
    public Context(DbContextOptions<Context> options) : base(options)
    {
    }
    
    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        modelBuilder.ApplyConfigurationsFromAssembly(Assembly.GetExecutingAssembly());
    }
}