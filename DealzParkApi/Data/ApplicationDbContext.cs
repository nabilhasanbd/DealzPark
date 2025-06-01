using Microsoft.EntityFrameworkCore;
using DealzParkApi.Models;

namespace DealzParkApi.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options)
        {

        }

        public DbSet<Shop> Shops { get; set; }
        public DbSet<Offer> Offers { get; set; }
        public DbSet<Category> Categories { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<Shop>()
                .HasMany(s => s.Offers)
                .WithOne(o => o.Shop)
                .HasForeignKey(o => o.ShopId)
                .OnDelete(DeleteBehavior.Cascade); // If a shop is deleted, its offers are deleted

            // Seed some categories for OfferCategory enum
            modelBuilder.Entity<Offer>()
                .Property(o => o.Category)
                .HasConversion<string>(); // Store enum as string

            modelBuilder.Entity<Category>().HasData(
                new Category { Id = 1, Name = "Fashion", CreatedAt = DateTime.UtcNow },
                new Category { Id = 2, Name = "Electronics", CreatedAt = DateTime.UtcNow },
                new Category { Id = 3, Name = "Food", CreatedAt = DateTime.UtcNow },
                new Category { Id = 4, Name = "Sports", CreatedAt = DateTime.UtcNow }
            );
        }
    }
}