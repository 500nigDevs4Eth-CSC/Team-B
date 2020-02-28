const CertVerify = artifacts.require('./CertVerify.sol');

require('chai')
	.use(require('chai-as-promised'))
	.should();

contract('CertVerify', ([deployer, admin, grade]) => {
	let certVerify;

	before(async () => {
		certVerify = await CertVerify.deployed();
	});

	describe('deployment', async () => {
		it('deploys successfully', async () => {
            const address = await certVerify.address
            assert.notEqual(address, 0x0),
            assert.notEqual(address, ''),
            assert.notEqual(address, null),
            assert.notEqual(address, undefined)
        });
	});

	describe('certification', async () => {
		let task, taskAssigned
		it('assign task', async () => {
			task = await certVerify.addAssignment("Task has been assigned", {from: admin });
			taskAssigned = await certVerify.taskAssigned()
			assert.equal(taskAssigned, 1);
			const event = task.logs[0].args
			assert(event.email, "Task has been assigned", "Task assigned os accurate")
			assert(event.email, "Task has been assigned", "Task assigned is accurate")
			assert(event.assignmentLink, "Assigment link is sent", "Assignment Link is accurate")
			assert(event.assignmentStatus, "Check Assignment Status", "Assignment Status is accurate")

			await certVerify.addAssignment('', {from: admin}).should.be.rejected;
		});

		it('grade students', async () => {
			
		});

		it('award certificate', async () => {
			
		})
	})
});
