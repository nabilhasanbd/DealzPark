using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using DealzParkApi.Data;
using DealzParkApi.Models;
using DealzParkApi.DTOs; // For CategoryCreationDto
using Swashbuckle.AspNetCore.Annotations;

namespace DealzParkApi.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class CategoriesController : ControllerBase
    {
        private readonly ApplicationDbContext _context;

        public CategoriesController(ApplicationDbContext context)
        {
            _context = context;
        }

        [HttpGet]
        [SwaggerOperation(Summary = "Gets all available categories")]
        [ProducesResponseType(typeof(IEnumerable<Category>), StatusCodes.Status200OK)]
        public async Task<ActionResult<IEnumerable<Category>>> GetAllCategories()
        {
            return await _context.Categories.OrderBy(c => c.Name).ToListAsync();
        }

        [HttpPost]
        [SwaggerOperation(Summary = "Creates a new category")]
        [ProducesResponseType(typeof(Category), StatusCodes.Status201Created)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        public async Task<ActionResult<Category>> CreateCategory([FromBody] CategoryCreationDto categoryDto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ModelState);
            }

            // Check if category already exists (case-insensitive for robustness)
            var existingCategory = await _context.Categories
                                        .FirstOrDefaultAsync(c => c.Name.ToLower() == categoryDto.Name.ToLower());

            if (existingCategory != null)
            {
                return BadRequest($"Category '{categoryDto.Name}' already exists.");
            }

            var category = new Category
            {
                Name = categoryDto.Name
                // CreatedAt is set by default
            };

            _context.Categories.Add(category);
            await _context.SaveChangesAsync();

            return CreatedAtAction(nameof(GetCategoryById), new { id = category.Id }, category);
        }

        // Optional: GetCategoryById (useful for CreatedAtAction)
        [HttpGet("{id}")]
        [SwaggerOperation(Summary = "Gets a specific category by ID")]
        [ProducesResponseType(typeof(Category), StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status404NotFound)]
        public async Task<ActionResult<Category>> GetCategoryById(int id)
        {
            var category = await _context.Categories.FindAsync(id);

            if (category == null)
            {
                return NotFound();
            }

            return category;
        }
    }
}